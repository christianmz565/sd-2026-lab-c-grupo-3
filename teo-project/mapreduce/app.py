import os


def run_master() -> None:
    print("role=master")


def run_worker() -> None:
    print("role=worker")


def main() -> None:
    role = os.environ.get("MAPREDUCE_ROLE", "worker").strip().lower()
    if role == "master":
        run_master()
        return
    if role == "worker":
        run_worker()
        return
    print(f"unknown role: {role}")


if __name__ == "__main__":
    main()
