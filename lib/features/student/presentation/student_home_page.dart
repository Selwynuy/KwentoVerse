import 'package:flutter/material.dart';
import 'student_theme.dart';

class StudentHomePage extends StatelessWidget {
  const StudentHomePage({super.key});

  static const _educators = [
    'Alina Slyshik',
    'Josh Funk',
    'Mandy Archer',
    'Zietlow Miller',
    'Hannah Peters',
  ];

  static const _schoolBooks = [
    'It\'s Not Hansel and Gretel',
    'Tonya',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSchoolCard(),
        const SizedBox(height: 20),
        _buildEducatorSection(),
        const SizedBox(height: 20),
        _buildSchoolLibrarySection(),
        const SizedBox(height: 16),
        _buildBookGrid(),
      ],
    );
  }

  Widget _buildSchoolCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: StudentTheme.cardLightOrange,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: StudentTheme.primaryOrange.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.school_rounded,
            color: StudentTheme.titleDark,
            size: 28,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'GSC SPED Integrated School',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: StudentTheme.titleDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEducatorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Educator',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: StudentTheme.titleDark,
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: const Text(
                'See More →',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: StudentTheme.titleDark,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _educators.length,
            separatorBuilder: (_, i) => const SizedBox(width: 16),
            itemBuilder: (context, i) {
              final name = _educators[i];
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: StudentTheme.cardLightOrange,
                    child: Icon(
                      Icons.person_rounded,
                      size: 28,
                      color: StudentTheme.primaryOrange,
                    ),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: 70,
                    child: Text(
                      name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: StudentTheme.titleDark,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSchoolLibrarySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'School Library',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: StudentTheme.titleDark,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          readOnly: true,
          decoration: InputDecoration(
            hintText: 'Search for books',
            hintStyle: const TextStyle(color: StudentTheme.secondaryGray),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: StudentTheme.secondaryGray,
              size: 22,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: StudentTheme.cardLightOrange),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: StudentTheme.cardLightOrange),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildBookGrid() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: StudentTheme.cardLightOrange,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: StudentTheme.primaryOrange.withValues(alpha: 0.2)),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.65,
          crossAxisSpacing: 16,
          mainAxisSpacing: 12,
        ),
        itemCount: _schoolBooks.length,
        itemBuilder: (context, i) {
          final title = _schoolBooks[i];
          return Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: const BookCoverPlaceholder(useConstraints: true),
              ),
              const SizedBox(height: 6),
              Text(
                title.toUpperCase(),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.15,
                  fontWeight: FontWeight.w600,
                  color: StudentTheme.titleDark,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
