# README - FairNotification

## About

Implementation of algorithms for auction-based notifications appearing in paper "Fair Notification Optimization: An Auction Approach", which can be accessed on arXiv: https://arxiv.org/abs/2302.04835.

## Notebooks

Detailed instructions on how to run the scripts can be found in the corresponding notebooks. 

### Notebook 1. 

The notebook `[notification_auction] simulation.ipynb` has two parts: learning and simulation.

In the learning portion, we learn the pacing multipliers of notification types (aka buyers) and the prices of users (aka sellers). Pacing parameters are estimated by solving an offline optimization problem (aka Eisenberg-Gale program).

In the simulation portion, starting from the pacing multipliers and prices learned, we simulate the auctions while updating the pacing multipliers and prices accordingly throughout the time horizon. 

### Notebook 2. 

The notebook `[notification_auction] metrics and plotting.ipynb` is for evaluating the performance of the auction outcomes. 

### Notebook 3.

The notebook `[notification_auction] derived dataset.ipynb` is for deriving dataset from the full dataset. These derived dataset can be useful to study fair online allocation and Fisher market equilibrium. See the following dataset section for more information on the derived datasets.  

## Dataset

The datasets can be accessed on ICPSR SOMAR. https://socialmediaarchive.org/record/55?&ln=en

### Full Dataset

The dataset contains all generated notifications for a subset of Instagram users across four notification types within a certain time window. Each entry of the dataset represents one generated notification and for each generated notification, we include some information related to the notification as well as information related to the auctions performed to determine if the generated notification can be sent to users (see the column description below for details). The dataset was collected during an A/B test where we compare the performance of the first-price auction system with that of the second-price auction system. 

The dataset has the following columns. 

1. event_id: Unique ID for every notification generation event.
2. user_id_anonymized: Anonymized user id.
3. notification_type: Type of the notification generated. 
4. auction_event_time: Timestamp (in seconds since epoch) when the notification was generated.
5. auction_event_date: Date (YYYY-MM-DD) at which the notification was generated.
6. notification_value: A machine learning model based score predicting affinity between the user and the generated notification, or the value of sending this generated notification.
7. auction_type: This indicates if in our data collecting experiment, was this user part of the first price auction type treatment group or the second price auction type treatment group. 
8. dummy_bidder_bid: This is the reserve price for the auction system. The notification is sent to the user only if the bid submitted by the notification type is greater than the dummy bidder value.
9. pacing_multiplier: This is the pacing multiplier used by the auction system to ensure uniform usage of the budget. The bid submitted by the notification type is the notification_value multiplied by the pacing_multiplier.
10. sent: This is a boolean value indicating if the notification was sent to the user or not.


### Derived Datasets

We constructed and released two derived datasets, which can be used to study fair online allocation and Fisher market equilibrium. They are different in terms of the length of time windows: for one, each time window is one day; for the other, each time window is two days. 

For each time window, the assumption on capacity is that every user can receive at most one notification. And for each time window, we keep the users if they receive at least two types of notifications, and consolidate the notifications generated for every such user. The datasets contain the following columns: 

1. auction_event_date — time window, which could be one day or two days
2. user_id_anonymized — anonymized user id
3. notification_type — list of notification types that generate notifications for the user on a given time window
4. notification_value — list of notification values, corresponding to notification types in notification_type
5. auction_event_time — the latest event time for all notifications generated for the user on a given time window

### Dataset for offline problems

One can also construct a dataset for the offline allocation problem by simply restricting to a certain time window and specifying the capacity constraints for each user. 

## License

FairNotification is licensed under CC-BY-NC-4.0 (see LICENSE file).
