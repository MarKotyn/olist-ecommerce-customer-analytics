import matplotlib.pyplot as plt
import seaborn as sns


# Helping functions for plot creations: set plot style
def set_plot_style():
    sns.set_theme(style="whitegrid",
                  palette="muted",
                  context="paper",
                  font="serif",
                  font_scale=1.1)

    plt.rcParams.update({
        # Figure changes
        "figure.figsize": (10, 6),
        'axes.edgecolor': "silver",
        'axes.linewidth': 0.5,

        # Grid changes
        "grid.color": "silver",
        "grid.alpha": 0.7,

        # Lines changes
        "lines.linewidth": 2.5
    })


# Create the figure for lineplot
def create_figure(rotate_x = True, sec_y = True):
    fig, ax1 = plt.subplots()
    if rotate_x:
        ax1.tick_params(axis='x', rotation=45)
    if sec_y:
        ax2 = ax1.twinx()
        ax2.grid(False)
        return fig, ax1, ax2
    else:
        return fig, ax1


# Add finishing touches
def finish_plot(ax1, title, xlabel, ax1_ylabel, legend=True, ax2=None, ax2_ylabel=None, ):
    ax1.set_title(title)
    ax1.set_xlabel(xlabel)
    ax1.set_ylabel(ax1_ylabel)

    if legend:
        ax1.legend(loc="upper left")

    if ax2 is not None:
        ax2.set_ylabel(ax2_ylabel)
        ax2.legend(loc="upper right")

    plt.tight_layout()
    plt.show()


# Define set style for metrics on plots
METRIC_CONFIG = {
    "total_orders": {
        "y": "total_orders",
        "color": "crimson",
        "label": "Total Orders"
    },
    "total_customers": {
        "y": "total_customers",
        "color": "forestgreen",
        "label": "Unique Customers"
    },
    "total_revenue": {
        "y": "total_revenue",
        "color": "royalblue",
        "label": "Total Revenue (BRL)"
    },
    "avg_order_value": {
        "y": "avg_order_value",
        "color": "purple",
        "label": "Avg Order Value (BRL)"
    },
    "cancellation_rate": {
        "y": "cancellation_rate",
        "color": "olive",
        "label": "Cancellation Rate (%)"
    },
    "unavailable_rate": {
        "y": "unavailable_rate",
        "color": "orange",
        "label": "Unavailable Rate (%)"
    },
    "total_spent": {
        "color": "navy"
    },
    "avg_freight": {
        "y": "avg_freight",
        "color": "plum"
    },
    "avg_delivery_days": {
        "y": "avg_delivery_days",
        "color": "teal",
        "label": "Avg Delivery Days"
    },
    "median_delivery_days": {
        "y": "median_delivery_days",
        "color": "cadetblue",
        "label": "Median Delivery Days",
        "linestyle": "dashed"
    },
    "avg_processing_days": {
        "y": "avg_processing_days",
        "color": "indigo",
        "label": "Avg Processing Days"
    },
    "avg_shipping_days": {
        "y": "avg_shipping_days",
        "color": "peru",
        "label": "Avg Shipping Days"
    },
    "completed_orders": {
        "y": "completed_orders",
        "color": "slategrey",
        "label": "Completed Orders"
    },
    "on_time_orders": {
        "y": "on_time_orders",
        "color": "limegreen",
        "label": "On Time Orders"
    },
    "late_orders": {
        "y": "late_orders",
        "color": "maroon",
        "label": "Late Orders"
    },
    "review_score": {
        "color": "chocolate"
    }
}

def annotate_bars(ax, fmt="{:.1f}", offset=3):
    """
    Add value labels to matplotlib/seaborn barplots.

    Parameters
    ----------
    ax : matplotlib.axes.Axes
        Axis containing the barplot.
    fmt : str, default="{:.1f}"
        Label format.
    offset : int, default=3
        Distance between the bar and the label (points).
    """

    for container in ax.containers:
        ax.bar_label(
            container,
            fmt=fmt,
            padding=offset,
            fontsize=8
        )