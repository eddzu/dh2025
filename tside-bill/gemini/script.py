# script.py

import sys
import PIL.Image as Image
import PIL
from google import genai
from google.genai import types
from io import BytesIO
from rembg import remove
import cv2
import json

def main():
    output_path = sys.argv[1] if len(sys.argv) > 1 else None
    if not output_path:
        print("No output path provided!")
        output_path = 'gemini/output.png'
    
    cap = cv2.VideoCapture(0)

    if not cap.isOpened():
        print("Error: Could not open webcam.")
        exit()

    while True:
        ret, frame = cap.read()
        
        if not ret:
            print("Failed to grab frame")
            break

        cv2.imshow('Webcam', frame)
        key = cv2.waitKey(1) & 0xFF

        # If 'c' is pressed, save the image and close
        if key == ord('c'):
            # Save the captured image
            cv2.imwrite('gemini/snapshot.png', frame)
            print("Snapshot saved as snapshot.png")
            break

        # If 'q' is pressed, quit the program
        elif key == ord('q'):
            print("Exiting without saving.")
            break

    cap.release()
    cv2.destroyAllWindows()

    image = PIL.Image.open('gemini/snapshot.png')

    client = genai.Client(api_key="AIzaSyAfkZyPTq02fxyT8x9r3suezXH4IR_9qNE")

    contents = ["Detect what is in the image and determine the main element. It should be a general item, but not too general. Store the main element in json format, not json file. It should \
                look as {\"name\":<determined_item_name>, \"color\": <color_of_the_item>}.", image]

    response = client.models.generate_content(
        model="gemini-2.0-flash-exp-image-generation",
        contents=contents,
        config=types.GenerateContentConfig(
          response_modalities=['Text']
        )
    )

    for part in response.candidates[0].content.parts:
        if part.text is not None:
            try:
                output_json = json.loads(part.text)
                print("JSON Output:", output_json)
                with open("data.json", "w") as f:
                    json.dump(output_json, f)
            except json.JSONDecodeError:
                print("Text Output:", part.text)

    with open("data.json", "r") as f:
        data = json.load(f)

    our_object = data["name"]
    our_object_color = data["color"]

    contents = [f"Then create a sprite of {our_object}. You should avoid using very bright colors and make it mainly in the color {our_object_color}. The object should be bordered with black. It should be 32x32px in size, so it is suitable for 2D game and store it as .png."]

    response = client.models.generate_content(
        model="gemini-2.0-flash-exp-image-generation",
        contents=contents,
        config=types.GenerateContentConfig(
          response_modalities=['Text', 'Image']
        )
    )

    for part in response.candidates[0].content.parts:
        if part.text is not None:
            print("Text Output:", part.text)
        elif part.inline_data is not None:
                image = Image.open(BytesIO((part.inline_data.data)))
                image.save('gemini/generated_sprite.png')

    input_path = 'gemini/generated_sprite.png'

    input_image = Image.open(input_path)
    output_image = remove(input_image)
    output_image.save(output_path)
    sys.exit(0)

if __name__ == "__main__":
    main()
