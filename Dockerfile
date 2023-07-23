FROM python:3.10-slim

ARG YOUR_ENV

ENV YOUR_ENV=${YOUR_ENV} \
  PYTHONFAULTHANDLER=1 \
  PYTHONUNBUFFERED=1 \
  PYTHONHASHSEED=random \
  PIP_NO_CACHE_DIR=off \
  PIP_DISABLE_PIP_VERSION_CHECK=on \
  PIP_DEFAULT_TIMEOUT=100 \
  POETRY_VERSION=1.5.1

RUN pip install -U pip
RUN apt-get update && apt-get install -y \
curl

RUN curl -sSL https://install.python-poetry.org | python3 - --version "${POETRY_VERSION}"
WORKDIR /app
ENV PATH=/app/.venv/bin:$PATH
ENV PATH="/root/.local/bin:$PATH"

COPY [ "pyproject.toml", "poetry.lock", "./" ]

RUN poetry config virtualenvs.create false \
  && poetry install --no-root

COPY [ "./deployment_attempt/predict.py", "./deployment_attempt/models/lin_reg.bin", "./" ]

EXPOSE 9696

ENTRYPOINT [ "gunicorn", "--bind=0.0.0.0:9696", "predict:app" ]