# Production Dockerfile for Flask application with Poetry
# Multi-architecture support for AMD64 and ARM64
FROM python:3.13-slim AS production

# Install Poetry with platform-specific optimizations
RUN pip install --no-cache-dir poetry

# Add platform information for debugging
ARG TARGETPLATFORM
ARG BUILDPLATFORM
RUN echo "Building on $BUILDPLATFORM, targeting $TARGETPLATFORM"

# Create non-root user for security
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Set working directory
WORKDIR /app

# Copy Poetry configuration files
COPY pyproject.toml poetry.lock* ./

RUN poetry config virtualenvs.create false && \
    poetry install --no-root

# Copy application source code
COPY src/ ./src/

# Change ownership to non-root user
RUN chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Add virtual environment to PATH
ENV PATH="/app/.venv/bin:$PATH"

# Configure environment variables
ENV PYTHONPATH=/app/src \
    PORT=5000

# Expose configurable port
EXPOSE $PORT

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD python -c "import urllib.request, os; urllib.request.urlopen(f'http://localhost:{os.environ.get(\"PORT\", \"5000\")}/')" || exit 1

# Run the Flask application
CMD ["python", "-m", "batchbuildgraph.app"]