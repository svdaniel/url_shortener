
def generate_short_url(size=10):
    import string
    import random

    chars = string.ascii_lowercase + string.digits

    return ''.join(random.choice(chars) for _ in range(size))

