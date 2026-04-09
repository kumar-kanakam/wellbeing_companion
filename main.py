from fastapi import FastAPI
import groq
import os
import base64
from elevenlabs.client import ElevenLabs

app = FastAPI() 

# --- PAID TIER APIS (Use Free Trials) ---
# ElevenLabs for Human Voice
eleven_client = ElevenLabs(api_key="sk_f8fa58b8dc40efb5a72fc36f942cf6bfb4666cddde52e0bb") 
# Groq for fast Brain
groq_client = groq.Groq(api_key="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") 

chat_history = []

@app.get("/chat")
async def get_response(user_msg: str, persona: str):
    global chat_history
    
    prompts = {
        "Mentor": "You are a funny English mentor. Use 'bro'. Be concise.",
        "Peer": "You are a cool college friend. Use casual English.",
        "Coach": "You are an empathetic wellness coach. Focus on reflective listening."
    }
    
    system_instruction = prompts.get(persona, prompts["Peer"])

    if not chat_history:
        chat_history.append({"role": "system", "content": system_instruction})

    chat_history.append({"role": "user", "content": user_msg})

    try:
        # 1. Groq Completion (Idi bagane undhi)
        chat_completion = groq_client.chat.completions.create(
            messages=chat_history,
            model="llama-3.1-8b-instant",
        )
        ai_reply = chat_completion.choices[0].message.content or "Sorry bro."

        # 2. FIXED: ElevenLabs Voice Generation Syntax for v1.0.0+
        try:
            # Rachel Voice ID: 21m00Tcm4TlvDq8ikWAM
            audio_generator = eleven_client.text_to_speech.convert(
                voice_id="pNInz6obpgDQGcFmaJgB", 
                text=ai_reply,
                model_id="eleven_multilingual_v2",
                output_format="mp3_44100_128",
            )
            
            # audio_generator stream ni bytes ga marchali
            audio_bytes = b"".join(audio_generator)
            audio_base64 = base64.b64encode(audio_bytes).decode('utf-8')
        except Exception as voice_err:
            print(f"Voice Error Debug: {voice_err}")
            audio_base64 = "" 

        return {
            "reply": ai_reply,
            "audio": audio_base64
        }
    except Exception as e:
        print(f"General Error: {e}")
        return {"reply": "Error: " + str(e), "audio": ""}