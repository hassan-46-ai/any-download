import 'package:flutter/material.dart';

/// Categories shown as chips on the home page. Each one maps to a search.
enum FeedCategory {
  trending('Trending', 'trending videos', Icons.local_fire_department_outlined),
  music('Music', 'music videos', Icons.music_note_outlined),
  gaming('Gaming', 'gaming', Icons.sports_esports_outlined),
  news('News', 'news today', Icons.newspaper_outlined),
  sports('Sports', 'sports highlights', Icons.sports_soccer_outlined),
  learning('Learning', 'educational', Icons.school_outlined),
  movies('Movies', 'movie trailers', Icons.movie_outlined);

  const FeedCategory(this.label, this.query, this.icon);

  final String label;
  final String query;
  final IconData icon;
}
