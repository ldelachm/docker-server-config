"""Main Flask application module."""

import os
from flask import Flask, jsonify
from datetime import datetime
import platform

from . import __version__


def create_app():
    """Create and configure the Flask application."""
    app = Flask(__name__)
    
    @app.route('/')
    def hello_world():
        """Root endpoint returning Hello World message and version information."""
        return jsonify({
            "message": "Hello World",
            "version": __version__,
            "timestamp": datetime.utcnow().isoformat() + "Z",
            "architecture": platform.machine()
        })
    
    return app


def main():
    """Main entry point for the Flask application."""
    app = create_app()
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=False)


if __name__ == '__main__':
    main()
