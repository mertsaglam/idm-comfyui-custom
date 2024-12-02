import base64
import json
import requests
import time


def convert_image_to_base64(image_path):
    with open(image_path, "rb") as image_file:
        encoded_string = base64.b64encode(image_file.read())
    return encoded_string.decode('utf-8')


human_image_b64 = convert_image_to_base64("./human.webp")
garment_image_b64 = convert_image_to_base64("./garment.webp")

sam_prompt = "blazer"
sam_threshold = 0.3

idm_vton_garment_description = "a shirt"
idm_vton_negative_prompt = "monochrome, lowres, bad anatomy, worst quality, low quality"

height = 1024
width = 768
num_inference_steps = 30
guidance_scale = 2.0
strength = 1.0
seed = 42

payload = json.dumps({
    "input": {
        "human_image_b64": human_image_b64,
        "garment_image_b64": garment_image_b64,
        "sam_prompt": sam_prompt,
        "sam_threshold": sam_threshold,
        "idm_vton_garment_description": idm_vton_garment_description,
        "idm_vton_negative_prompt": idm_vton_negative_prompt,
        "height": height,
        "width": width,
        "num_inference_steps": num_inference_steps,
        "guidance_scale": guidance_scale,
        "strength": strength,
        "seed": seed,
    }
})
start = time.time()

endpoint_url = "https://api.runpod.ai/v2/urlasd"
headers = {
    'authorization': "token",
    'content-type': 'application/json',
}

response = requests.request(
    "POST", f"{endpoint_url}/run", headers=headers, data=payload)

data = response.json()

job_id = data["id"]
job_finished = False
result = None

while not job_finished:
    time.sleep(1)
    response = requests.request(
        "GET", f"{endpoint_url}/status/{job_id}", headers=headers)
    result = response.json()

    job_finished = result["status"] == "COMPLETED"

base64_image = result['output']['payload']['result']
image_data = base64.b64decode(base64_image)

end = time.time()

with open("result.png", "wb") as f:
    f.write(image_data)

print("Total time take (sec):", end-start)
