# START-SNIPPET,map
import re
from collections import Counter
from typing import Dict

def run_map(text_chunk: str) -> Dict[str, int]:
    """
    Get a text chunk, clean it, and return a dictionary with word counts.
    """
    clear_text = text_chunk.lower()
    words = re.findall(r"\b[a-zñáéíóúü]+\b", clear_text)
    return dict(Counter(words))
# END-SNIPPET
