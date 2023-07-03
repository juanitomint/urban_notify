# CONSUME BUILD ARGS FOR TRACE
FROM python:3.11-slim as base

ARG VCS_REF
ARG BUILD_DATE
ARG GIT_USER
ARG GIT_USER_EMAIL
ARG IMAGE_TAG
LABEL org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.git_user=$GIT_USER \
      org.label-schema.git_user_email=$GIT_USER_EMAIL



FROM base AS python-deps
RUN pip install poetry
COPY pyproject.toml poetry.lock ./
RUN  poetry config virtualenvs.in-project true && poetry install --only main

FROM base AS runtime
WORKDIR /usr/local/app
COPY --from=python-deps /.venv /.venv
ENV PATH="/.venv/bin:$PATH"
COPY main.py .env pyproject.toml ./
ENTRYPOINT [ "/usr/local/app/main.py" ]

