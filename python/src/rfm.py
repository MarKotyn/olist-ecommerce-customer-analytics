# RFM Scores and Segments
RFM_LEVELS = {
    "High": [4, 5],
    "Mid": [3],
    "Low": [1, 2]
}

RFM_SEGMENTS = {
    "Champions": {
        "R": "High",
        "F": "High",
        "M": "High",
        "Description": "Best and most valuable customers.",
        "Typical Actions": "Loyalty program, VIP treatment, early access.",
    },

    "Loyal Customers": {
        "R": ["Mid", "High"],
        "F": "High",
        "M": ["Low", "Mid", "High"],
        "Description": "Frequent customers who remain relatively active.",
        "Typical Actions": "Personalized offers, loyalty rewards, ask for reviews.",
    },

    "Cannot Lose Them": {
        "R": "Low",
        "F": "High",
        "M": ["Mid", "High"],
        "Description": "Previously valuable and frequent customers who have not purchased recently.",
        "Typical Actions": "Personalized win-back campaign, direct contact, exclusive offer.",
    },

    "At Risk": {
        "R": "Low",
        "F": ["Mid", "High"],
        "M": ["Low", "Mid", "High"],
        "Description": "Previously engaged customers whose activity has declined.",
        "Typical Actions": "Win-back offers, satisfaction survey, personalized reminder.",
    },

    "Potential Loyalists": {
        "R": "High",
        "F": "Mid",
        "M": ["Low", "Mid", "High"],
        "Description": "Recent customers who have already made more than one purchase.",
        "Typical Actions": "Loyalty invitation, personalized recommendation, next-order incentive.",
    },

    "New Customers": {
        "R": "High",
        "F": "Low",
        "M": ["Low", "Mid", "High"],
        "Description": "Recent customers with limited purchase history.",
        "Typical Actions": "Onboarding, product recommendations, next-order discount.",
    },

    "Needs Attention": {
        "R": "Mid",
        "F": ["Low", "Mid"],
        "M": ["Low", "Mid", "High"],
        "Description": "Customers with moderate or declining engagement.",
        "Typical Actions": "Relevant offers, reminders, engagement campaign.",
    },

    "Hibernating": {
        "R": "Low",
        "F": "Low",
        "M": ["Low", "Mid", "High"],
        "Description": "Inactive customers with little purchase activity.",
        "Typical Actions": "Low-cost reactivation campaign, newsletter, automated offers.",
    },
}

# Assign score for RFM analysis
def assign_f_score(orders):
    if orders == 1:
        return 1
    elif orders == 2:
        return 3
    else:
        return 5

def get_allowed_scores(levels, score_mapping):
    if isinstance(levels, str):
        levels = [levels]

    return [
        score
        for level in levels
        for score in score_mapping[level]
    ]

def assign_rfm_segment(
    row,
    segments=RFM_SEGMENTS,
    score_mapping=RFM_LEVELS,
):
    for segment_name, config in segments.items():

        allowed_r = get_allowed_scores(
            config["R"],
            score_mapping,
        )

        allowed_f = get_allowed_scores(
            config["F"],
            score_mapping,
        )

        allowed_m = get_allowed_scores(
            config["M"],
            score_mapping,
        )

        if (
            row["R_Score"] in allowed_r
            and row["F_Score"] in allowed_f
            and row["M_Score"] in allowed_m
        ):
            return segment_name

    return "Other"