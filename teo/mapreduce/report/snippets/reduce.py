# START-SNIPPET,reduce
from typing import List

def run_reduce(mapped_data: List[dict]) -> dict:
    """
    Take a list of dictionaries (partial word counts from the map phase) and combine them into a single dictionary with total counts.
    """
    total_counts = {}
    for partial_counts in mapped_data:
        for word, count in partial_counts.items():
            if word in total_counts:
                total_counts[word] += count
            else:
                total_counts[word] = count
    return total_counts
# END-SNIPPET
