
from pathlib import Path
from joblib import load
from transaction_extractor import extract_transaction

BASE_DIR = Path(__file__).resolve().parent
MODEL_PATH = BASE_DIR / "notification_classifier.joblib"

model = load(MODEL_PATH)


def process_notification(message):
    prediction = model.predict([message])[0]

    result = {
        "notification": message,
        "classification": prediction,
        "transaction": None
    }

    if prediction == "transaction":
        result["transaction"] = extract_transaction(message)

    return result


if __name__ == "__main__":
    test_messages = [
        "Rs. 500 debited from your account at ABC Store",
        "You received Rs. 1200 through UPI",
        "Your OTP for login is 123456",
        "You have a new Instagram message"
    ]

    for message in test_messages:
        print("\n", process_notification(message))
