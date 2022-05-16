from fastapi import FastAPI, File, UploadFile
import os

# A simple file upload API for use in iCloud backups

app = FastAPI()

@app.post("/recv")
async def recv_files(file: UploadFile):
        path = f"/Users/frostpaw/Documents/{file.filename}"
        os.makedirs("/".join(path.split("/")[:-1]), exist_ok=True)

        with open(path, "wb") as p:
                p.write((await file.read()))
