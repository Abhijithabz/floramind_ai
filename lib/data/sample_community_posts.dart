import '../models/community_post.dart';

final List<CommunityPost> sampleCommunityPosts = <CommunityPost>[
  CommunityPost(
    id: 'post-001',
    authorName: 'Aarav Mehta',
    authorRole: 'Home Gardener',
    category: 'Disease',
    plantName: 'Rose',
    title: 'Dark spots spreading on my rose leaves',
    problemDescription:
        'The leaves started showing circular brown patches after the last rain. I want to know if this is fungal or a watering issue.',
    timeLabel: '12m ago',
    likeCount: 24,
    saveCount: 8,
    comments: const [
      CommunityComment(
        authorName: 'Flora Guide',
        message:
            'This looks like early leaf spot. Try removing affected leaves and improving airflow.',
        timeLabel: '7m ago',
        isHelpful: true,
      ),
      CommunityComment(
        authorName: 'Maya',
        message: 'Avoid wetting the leaves in the evening.',
        timeLabel: '5m ago',
      ),
    ],
  ),
  CommunityPost(
    id: 'post-002',
    authorName: 'Nisha Rao',
    authorRole: 'Balcony Gardener',
    category: 'Care',
    plantName: 'Money Plant',
    title: 'Best way to keep my money plant lush indoors?',
    problemDescription:
        'The plant is alive, but the growth is slow. I keep it near a bright window and water once a week.',
    timeLabel: '1h ago',
    likeCount: 36,
    saveCount: 14,
    comments: const [
      CommunityComment(
        authorName: 'Karan',
        message: 'Add a little liquid fertilizer every 3-4 weeks.',
        timeLabel: '35m ago',
        isHelpful: true,
      ),
      CommunityComment(
        authorName: 'Aditi',
        message: 'Rotate the pot so all sides get light.',
        timeLabel: '20m ago',
      ),
    ],
  ),
  CommunityPost(
    id: 'post-003',
    authorName: 'Rahul Singh',
    authorRole: 'Terrace Grower',
    category: 'Pests',
    plantName: 'Tulsi',
    title: 'Tiny insects on the underside of the leaves',
    problemDescription:
        'I found small insects and some sticky residue on tulsi leaves. The plant is otherwise healthy.',
    timeLabel: '3h ago',
    likeCount: 19,
    saveCount: 5,
    comments: const [
      CommunityComment(
        authorName: 'Flora Guide',
        message:
            'This can be aphids. Try a mild neem spray and inspect new growth every 2 days.',
        timeLabel: '1h ago',
        isHelpful: true,
      ),
    ],
  ),
  CommunityPost(
    id: 'post-004',
    authorName: 'Ishita Das',
    authorRole: 'Plant Beginner',
    category: 'Propagation',
    plantName: 'Hibiscus',
    title: 'Can I propagate from a soft stem cutting?',
    problemDescription:
        'I want to start a new hibiscus plant from the one on my porch. What cutting length works best?',
    timeLabel: '5h ago',
    likeCount: 42,
    saveCount: 18,
    comments: const [
      CommunityComment(
        authorName: 'Dev',
        message: 'Use a healthy 6-8 inch cutting with a few leaves trimmed back.',
        timeLabel: '2h ago',
        isHelpful: true,
      ),
      CommunityComment(
        authorName: 'Riya',
        message: 'Rooting gel helps, but humidity matters most.',
        timeLabel: '1h ago',
      ),
    ],
  ),
];

