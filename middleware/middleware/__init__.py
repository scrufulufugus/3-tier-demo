import uvicorn
import argparse

def main():
    parser = argparse.ArgumentParser(description="Middleware")
    parser.add_argument("--host", type=str, default="0.0.0.0", help="Hostname to bind to, defaults to 0.0.0.0")
    parser.add_argument("--port", type=int, default=8000, help="Port to bind to, defaults to 8000")
    args = parser.parse_args()
    uvicorn.run("middleware.app:app", host=args.host, port=args.port, reload=True)

if __name__ == '__main__':
    main()
