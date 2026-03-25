import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:northern_trader/features/reviews/repository/reviews_repository.dart';
import 'package:northern_trader/models/review.dart';

final reviewsControllerProvider = Provider<ReviewsController>((ref) {
  final reviewsRepository = ref.watch(reviewsRepositoryProvider);
  return ReviewsController(reviewsRepository: reviewsRepository);
});

// Провайдер для всех обзоров
final allReviewsProvider = StreamProvider<List<Review>>((ref) {
  final reviewsController = ref.watch(reviewsControllerProvider);
  return reviewsController.getAllReviews();
});

// Провайдер для последних обзоров (для главной страницы)
final latestReviewsProvider = StreamProvider<List<Review>>((ref) {
  final reviewsController = ref.watch(reviewsControllerProvider);
  return reviewsController.getLatestReviews(limit: 3);
});

// Провайдер для обзоров по категории
final reviewsByCategoryProvider = StreamProvider.family<List<Review>, String>((ref, category) {
  final reviewsController = ref.watch(reviewsControllerProvider);
  return reviewsController.getReviewsByCategory(category);
});

class ReviewsController {
  final ReviewsRepository reviewsRepository;

  ReviewsController({required this.reviewsRepository});

  // Получить все обзоры
  Stream<List<Review>> getAllReviews({int limit = 50}) {
    return reviewsRepository.getAllReviews(limit: limit);
  }

  // Получить обзоры по категории
  Stream<List<Review>> getReviewsByCategory(String category, {int limit = 50}) {
    return reviewsRepository.getReviewsByCategory(category, limit: limit);
  }

  // Получить последние обзоры
  Stream<List<Review>> getLatestReviews({int limit = 3}) {
    return reviewsRepository.getLatestReviews(limit: limit);
  }

  // Получить обзор по ID
  Future<Review?> getReviewById(String reviewId) {
    return reviewsRepository.getReviewById(reviewId);
  }

  // Увеличить счетчик просмотров
  Future<void> incrementViews(String reviewId) {
    return reviewsRepository.incrementViews(reviewId);
  }

  // Создать обзор (для будущего функционала)
  Future<void> createReview(Review review) {
    return reviewsRepository.createReview(review);
  }

  // Обновить обзор (для будущего функционала)
  Future<void> updateReview(Review review) {
    return reviewsRepository.updateReview(review);
  }

  // Удалить обзор (для будущего функционала)
  Future<void> deleteReview(String reviewId) {
    return reviewsRepository.deleteReview(reviewId);
  }
}
