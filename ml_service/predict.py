
from pathlib import Path
from joblib import load

BASE_DIR = Path(__file__).resolve().parent
MODEL_PATH = BASE_DIR / "notification_classifier.joblib"

model = load(MODEL_PATH)

messages = [
    "Rs. 500 debited from your account at ABC Store",
    "You received Rs. 1200 through UPI",
    "Your OTP for login is 123456",
    "You have a new Instagram message",
    "Your monthly bank statement is ready"
]

for message in messages:
    prediction = model.predict([message])[0]
    print(f"\nNotification: {message}")
    print(f"Prediction: {prediction}")
