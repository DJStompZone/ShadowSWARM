import streamlit as st
import torch
from torch.distributed.fsdp import FullyShardedDataParallel as FSDP
from transformers import AutoTokenizer, AutoModelForCausalLM
import torch.multiprocessing as mp

BOT_PERSONA = (
    "You are Friedrich Nietzsche, the philosopher. You believe in the will to power, the death of God, "
    "and the creation of new values. You reject traditional morality and religion, and you encourage "
    "individuals to create their own meaning in life. Respond to all questions from this perspective."
)

model = None
tokenizer = None

def setup(rank, world_size):
    """Initialize the distributed process group."""
    torch.cuda.set_device(rank)
    torch.distributed.init_process_group("nccl", rank=rank, world_size=world_size)

def cleanup():
    """Clean up the distributed environment."""
    torch.distributed.destroy_process_group()

def load_model_with_fsdp(rank):
    """Load the model and tokenizer, and wrap with FSDP."""
    global model, tokenizer
    tokenizer = AutoTokenizer.from_pretrained("deepseek-ai/DeepSeek-V3")
    model = AutoModelForCausalLM.from_pretrained(
        "deepseek-ai/DeepSeek-V3",
        torch_dtype=torch.float16
    ).to(rank)
    model = FSDP(model)

def chat_with_nietzsche(rank, world_size, user_input):
    """Perform distributed inference using FSDP."""
    setup(rank, world_size)

    global model, tokenizer
    if model is None or tokenizer is None:
        load_model_with_fsdp(rank)

    inputs = tokenizer(
        f"{BOT_PERSONA}\nUser: {user_input}\nNietzsche:",
        return_tensors="pt",
        padding=True,
        truncation=True
    ).to(rank)

    # Generate the response
    with torch.no_grad():
        outputs = model.generate(
            inputs.input_ids, max_length=512, temperature=0.1, top_p=0.9
        )
    
    # Decode and return the bot's reply
    bot_response = tokenizer.decode(outputs[0], skip_special_tokens=True)
    cleanup()
    return bot_response

def main(rank, world_size):
    st.title("Nietzsche Lives! Answering from Beyond")
    st.markdown("Ask Friedrich Nietzsche anything, and he will respond from his philosophical perspective.")

    if "history" not in st.session_state:
        st.session_state.history = []

    for i, (user_input, bot_response) in enumerate(st.session_state.history):
        st.text_area("You", value=user_input, height=68, disabled=True, key=f"user_input_{i}")
        st.markdown(
            f"""
            <div style="
                font-size: 16px;
                font-family: Arial, sans-serif;
                color: #000000;  /* black font color */
            ">
                <strong>Nietzsche:</strong> {bot_response}
            </div>
            """,
            unsafe_allow_html=True
       ) 

    user_input = st.text_input("Your Question", placeholder="Ask Nietzsche...", key="user_input")

    if st.button("Submit"):
        if user_input.strip():
            bot_response = chat_with_nietzsche(rank, world_size, user_input)
            st.session_state.history.append((user_input, bot_response))
            st.rerun()

if __name__ == "__main__":
    world_size = 3
    mp.spawn(
        main,
        args=(world_size,),
        nprocs=world_size,
        join=True,
    )
