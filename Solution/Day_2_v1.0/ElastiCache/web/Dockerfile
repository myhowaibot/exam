FROM python:3.11
WORKDIR /web

COPY . .
RUN pip install -r requirements.txt

ENTRYPOINT [ "python3", "web.py" ]