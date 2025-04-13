import sys
import json
import re
from google import genai
from google.genai import types

def main():
    if len(sys.argv) < 2:
        print("Usage: python grumpy_professor.py <item_name>")
        sys.exit(1)

    item_name = sys.argv[1].lower()

    client = genai.Client(api_key="AIzaSyAfkZyPTq02fxyT8x9r3suezXH4IR_9qNE")

    prompt = f"""
You are an old, grumpy professor. The user brought you '{item_name}'.
Decide if it can be used as a cup for coffee.
Respond only as valid JSON: {{"text_answer": "<short witty or happy reply under 15 words>", "decision": true/false}}.
If the item is suitable for coffee, set decision to true.
If not, set decision to false.
Do not include code fences, markdown, or explanations.
Only output the JSON object. No extra text.
"""

    response = client.models.generate_content(
        model="gemini-2.0-flash",
        contents=[prompt],
        config=types.GenerateContentConfig(
            response_modalities=["Text"]
        )
    )

    # Combine all parts into a single string
    gemini_text = ""
    for part in response.candidates[0].content.parts:
        if part.text:
            gemini_text += part.text

    gemini_text = gemini_text.strip()

    # Try direct JSON parse
    try:
        parsed = json.loads(gemini_text)
        print("✅ Parsed Gemini JSON:")
        print(json.dumps(parsed, indent=2))
        return
    except json.JSONDecodeError:
        pass  # fallback to regex if direct parse fails

    # Regex fallback: extract the JSON object from the text
    match = re.search(r"\{.*\}", gemini_text, flags=re.DOTALL)
    if match:
        json_snippet = match.group(0)
        try:
            parsed = json.loads(json_snippet)
            print("✅ Parsed JSON snippet:")
            print(json.dumps(parsed, indent=2))
        except json.JSONDecodeError:
            print("❌ Failed to parse JSON even after extracting snippet.")
            print("Raw Gemini output:\n", gemini_text)
    else:
        print("❌ No JSON object found in Gemini output.")
        print("Raw output:\n", gemini_text)

if __name__ == "__main__":
    main()
