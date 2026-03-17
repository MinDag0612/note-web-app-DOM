# NoteWeb

## Overview
NoteWeb is a web-based note management application built with React and Python backend. 
It allows users to create, edit, and organize personal notes.

## Architecture
The system follows a client-server architecture.

Frontend:
- ReactJS
- Bootstrap

Backend:
- Python API service (FastAPI)

Database:
- MongoDB (MongoDB Atlas)

## Run Steps

1. Clone the repository

git clone https://github.com/MinDag0612/note-web-app-DOM.git

2. Install dependencies

npm install

3. Start the application

npm run dev

4. Run backend

pip install -r requirements.txt

python main.py


## Backend API

The backend is implemented using FastAPI and provides APIs for:
- User authentication
- Note management

## Frontend by ReactJS
- Add frontend structure
- Note include build and node_module

## Deployment
- Deploy process is descrise in Deploy-step.md

## Deployment Notes

The application can be deployed on a Linux server using the script in /scripts.

Run:

bash scripts/deploy.sh

Note: The .env file is not included in the repository. 
Please copy .env.example and create your own .env file before running the deployment script.
