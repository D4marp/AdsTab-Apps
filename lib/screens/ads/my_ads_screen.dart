import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ad_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/ad_card.dart';
import 'create_ad_screen.dart';

class MyAdsScreen extends StatefulWidget {
  const MyAdsScreen({super.key});

  @override
  State<MyAdsScreen> createState() => _MyAdsScreenState();
}

class _MyAdsScreenState extends State<MyAdsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().user?.uid ?? '';
      context.read<AdProvider>().fetchUserAds(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Advertisements'),
        elevation: 0,
      ),
      body: Consumer<AdProvider>(
        builder: (context, adProvider, _) {
          if (adProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (adProvider.userAds.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.campaign_outlined,
                      size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No advertisements yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your first ad to get started',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CreateAdScreen(),
                      ),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('Create Ad'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: adProvider.userAds.length,
            itemBuilder: (context, index) {
              final ad = adProvider.userAds[index];
              return AdCard(
                ad: ad,
                onEdit: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreateAdScreen(),
                  ),
                ),
                onDelete: () => _showDeleteDialog(context, ad.id),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const CreateAdScreen(),
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String adId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Advertisement'),
        content: const Text('Are you sure you want to delete this ad?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final userId =
                  context.read<AuthProvider>().user?.uid ?? '';
              context.read<AdProvider>().deleteAd(adId, userId);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
