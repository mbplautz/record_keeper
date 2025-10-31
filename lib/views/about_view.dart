import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width * 0.9;
    if (width > 300) {
      width = 300;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // App logo / splash image
          Center(
            child: Image.asset(
              'assets/images/splash-screen.png',
              width: width,
              height: width,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 24),

          // Author name
          Text(
            'Written by Michael Plautz',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),

          // Version text
          Text(
            'Version 1.0.0',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),

          // Conditional text for iOS/macOS
          if (Platform.isIOS || Platform.isMacOS)
            Text(
              'Distributed by Bryan Ratledge',
              style: TextStyle(fontSize: 16),
            ),
          const SizedBox(height: 16),

          // Description with hyperlinks
          Wrap(
            alignment: WrapAlignment.start,
            children: [
              ...('Record Keeper is an Open Source app written using'
                .split(' ')
                .map((word) => Text('$word ', style: const TextStyle(fontSize: 16))).toList()),
              GestureDetector(
                onTap: () => _launchUrl('https://dart.dev'),
                child: const Text(
                  'Dart',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const Text(' and ', style: TextStyle(fontSize: 16)),
              GestureDetector(
                onTap: () => _launchUrl('https://flutter.dev'),
                child: const Text(
                  'Flutter',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const Text('.', style: TextStyle(fontSize: 16)),
            ],
          ),
          const SizedBox(height: 32),

          // List items with images and hyperlinks
          _buildLinkItem(
            imagePath: 'assets/images/github-logo.png',
            label: 'record_keeper GitHub repository',
            url: 'https://github.com/mbplautz/record_keeper',
          ),
          _buildLinkItem(
            imagePath: 'assets/images/dart-logo.png',
            label: 'Dart programming language',
            url: 'https://dart.dev',
          ),
          _buildLinkItem(
            imagePath: 'assets/images/flutter-logo.png',
            label: 'Flutter UI',
            url: 'https://flutter.dev',
          ),
        ],
      ),
    );
  }

  Widget _buildLinkItem({
    required String imagePath,
    required String label,
    required String url,
  }) {
    return InkWell(
      onTap: () => _launchUrl(url),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Image.asset(
              imagePath,
              width: 64,
              height: 64,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  //color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
