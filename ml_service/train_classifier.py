
from pathlib import Path

import pandas as pd
from joblib import dump
from sklearn.model_selection import train_test_split
from sklearn.pipeline import Pipeline
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import classification_report

BASE_DIR = Path(__file__).resolve().parent
DATA_PATH = BASE_DIR / "dataset" / "notifications.csv"
MODEL_PATH = BASE_DIR / "notification_classifier.joblib"

df = pd.read_csv(DATA_PATH)
df = df.dropna(subset=["notification_text", "label"])

X = df["notification_text"].astype(str)
y = df["label"].astype(str)

X_train, X_test, y_train, y_test = train_test_split(
    X, y,
    test_size=0.2,
    random_state=42,
    stratify=y
)

model = Pipeline([
    ("tfidf", TfidfVectorizer(ngram_range=(1, 2))),
    ("classifier", LogisticRegression(max_iter=1000))
])

model.fit(X_train, y_train)

predictions = model.predict(X_test)

print("Model evaluation:")
print(classification_report(y_test, predictions))

dump(model, MODEL_PATH)
print(f"Model saved to: {MODEL_PATH}")
