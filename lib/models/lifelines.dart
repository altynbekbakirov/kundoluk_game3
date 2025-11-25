class Lifelines {
  bool fiftyFifty;
  bool callFriend;
  bool audienceVote;

  Lifelines({
    this.fiftyFifty = true,
    this.callFriend = true,
    this.audienceVote = true,
  });

  void reset() {
    fiftyFifty = true;
    callFriend = true;
    audienceVote = true;
  }

  Lifelines copyWith({
    bool? fiftyFifty,
    bool? callFriend,
    bool? audienceVote,
  }) {
    return Lifelines(
      fiftyFifty: fiftyFifty ?? this.fiftyFifty,
      callFriend: callFriend ?? this.callFriend,
      audienceVote: audienceVote ?? this.audienceVote,
    );
  }
}

