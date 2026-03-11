import '../domain/story.dart';

class LocalStoryRepository {
  const LocalStoryRepository();

  Story? getById(String id) {
    return _stories[id];
  }
}

const _sampleStory = Story(
  id: 'sample-1',
  title: "It's Not Hansel and Gretel",
  author: 'Josh Funk',
  description:
      '“It’s Not Hansel and Gretel” flips the classic fairy tale on its head as Hansel and Gretel, fed up with their predictable roles, rebel against the narrator’s control. With witty banter, wild detours, and a forest full of quirky characters, the siblings prove that they’re not just pieces in a story—they’re ready to rewrite it entirely.',
  difficultyLabel: 'Slice of Life',
  estimatedMinutes: 6,
  readsCount: 1284,
  averageRating: 4.6,
  coverAssetPath: 'assets/kwentoverse_logo.png',
  paragraphs: [
    "Hansel and Gretel ignored the narrator’s orders to stick to the trail.",
    "“We’re not eating candy houses,” Gretel said.",
    "“And we’re not getting lost!” Hansel added, trading breadcrumbs with crows for shiny pebbles.",
    "The narrator cleared his throat. Loudly.",
    "But the children had already stepped off the path—into a forest where stories didn’t behave.",
    "Somewhere ahead, something glittered like a clue… or a trap.",
  ],
);

final Map<String, Story> _stories = {
  _sampleStory.id: _sampleStory,
};

