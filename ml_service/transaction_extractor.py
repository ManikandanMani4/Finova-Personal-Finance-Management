
import re


def extract_transaction(message):
    # Extract the transaction amount
    amount_match = re.search(
        r'(?:Rs\.?|INR|₹)\s*([\d,]+(?:\.\d{1,2})?)',
        message,
        re.IGNORECASE
    )

    amount = None
    if amount_match:
        amount = float(amount_match.group(1).replace(",", ""))

    # Identify debit or credit
    text = message.lower()

    debit_words = ["debited", "spent", "paid", "withdrawn"]
    credit_words = ["credited", "received", "deposited"]

    if any(word in text for word in debit_words):
        transaction_type = "debit"
    elif any(word in text for word in credit_words):
        transaction_type = "credit"
    else:
        transaction_type = "unknown"

    # Extract a merchant from common message patterns
    merchant_match = re.search(
        r'\bat\s+(.+?)(?:\s+on\s+|\s+ref(?:erence)?\b|[.]?$)',
        message,
        re.IGNORECASE
    )

    merchant = merchant_match.group(1).strip(" .") if merchant_match else None

    return {
        "amount": amount,
        "type": transaction_type,
        "merchant": merchant
    }


if __name__ == "__main__":
    message = "Rs. 500 debited from your account at ABC Store"

    result = extract_transaction(message)

    print("Notification:", message)
    print("Extracted details:", result)
