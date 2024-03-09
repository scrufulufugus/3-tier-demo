import uvicorn
import argparse

def main():
    parser = argparse.ArgumentParser(description="Middleware")
    parser.add_argument("-H", "--host", type=str, default="localhost", help="Hostname to bind to, defaults to localhost")
    parser.add_argument("-p", "--port", type=int, default=8000, help="Port to bind to, defaults to 8000")
    args = parser.parse_args()
    uvicorn.run("middleware.app:app", host=args.host, port=args.port, reload=True)

if __name__ == '__main__':
    main()
