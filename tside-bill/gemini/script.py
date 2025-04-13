import sys
import PIL.Image as Image
import PIL
from google import genai
from google.genai import types
from io import BytesIO
from rembg import remove
import cv2
import json
import os

def main():
    output_path = sys.argv[1] if len(sys.argv) > 1 else None
    if not output_path:
        print("No output path provided!")
        output_path = 'gemini/output.png'

    # --- get the directory from output_path ---
    output_dir = os.path.dirname(output_path)
    if not output_dir:
        # If output_path has no directory (e.g. just 'output.png'),
        # treat current working directory as output directory
        output_dir = '.'
    
    # create the directory if it doesn’t exist
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    data_json_path = os.path.join(output_dir, "data.json")

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
            snapshot_path = os.path.join(output_dir, 'snapshot.png')
            cv2.imwrite(snapshot_path, frame)
            print("Snapshot saved as snapshot.png")
            break

        # If 'q' is pressed, quit the program
        elif key == ord('q'):
            print("Exiting without saving.")
            break

    cap.release()
    cv2.destroyAllWindows()

    # open the snapshot from the same directory
    image = PIL.Image.open(snapshot_path)

    client = genai.Client(api_key="AIzaSyAfkZyPTq02fxyT8x9r3suezXH4IR_9qNE")

    contents = [
        "Detect what is in the image and determine the main element. "
        "It should be a general item, but not too general. Store the main "
        "element in json format, not json file. It should look like "
        '{"name":<determined_item_name>, "color": <color_of_the_item>}.',
        image
    ]

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
                with open(data_json_path, "w") as f:
                    json.dump(output_json, f)
            except json.JSONDecodeError:
                print("Text Output:", part.text)

    # read the data.json from the same directory
    with open(data_json_path, "r") as f:
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
            img = Image.open(BytesIO((part.inline_data.data)))
            generated_sprite_path = os.path.join(output_dir, 'generated_sprite.png')
            img.save(generated_sprite_path)

    input_image = Image.open(generated_sprite_path)
    output_image = remove(input_image)
    output_image.save(output_path)
    sys.exit(0)

if __name__ == "__main__":
    main()
