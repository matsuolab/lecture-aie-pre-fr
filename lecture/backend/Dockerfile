# --- Étape de construction ---
FROM python:3.12-slim AS builder

WORKDIR /app

# Créer un environnement virtuel
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

COPY requirements.txt .
# Exécuter les commandes dans l'ordre avec &&
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt


# --- Étape d'exécution ---
FROM python:3.12-slim AS runner
WORKDIR /app

# Copier l'environnement virtuel complet depuis l'étape de construction
COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Mettre en place le code de l'application
COPY . /app/

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]