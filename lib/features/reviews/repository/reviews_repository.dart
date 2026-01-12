import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:northern_trader/models/review.dart';
import 'package:uuid/uuid.dart';

final reviewsRepositoryProvider = Provider<ReviewsRepository>((ref) {
  return ReviewsRepository(firestore: FirebaseFirestore.instance);
});

class ReviewsRepository {
  final FirebaseFirestore firestore;

  ReviewsRepository({required this.firestore});

  // Получить все обзоры
  Stream<List<Review>> getAllReviews({int limit = 50}) {
    return firestore
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Review.fromMap(doc.data());
      }).toList();
    });
  }

  // Получить обзоры по категории
  Stream<List<Review>> getReviewsByCategory(String category, {int limit = 50}) {
    return firestore
        .collection('reviews')
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Review.fromMap(doc.data());
      }).toList();
    });
  }

  // Получить последние N обзоров для главной страницы
  Stream<List<Review>> getLatestReviews({int limit = 3}) {
    return firestore
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Review.fromMap(doc.data());
      }).toList();
    });
  }

  // Получить обзор по ID
  Future<Review?> getReviewById(String reviewId) async {
    try {
      final doc = await firestore.collection('reviews').doc(reviewId).get();
      if (doc.exists) {
        return Review.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Ошибка при получении обзора: $e');
    }
  }

  // Увеличить счетчик просмотров
  Future<void> incrementViews(String reviewId) async {
    try {
      await firestore.collection('reviews').doc(reviewId).update({
        'views': FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception('Ошибка при обновлении просмотров: $e');
    }
  }

  // Создать новый обзор (для будущего функционала)
  Future<void> createReview(Review review) async {
    try {
      await firestore.collection('reviews').doc(review.id).set(review.toMap());
    } catch (e) {
      throw Exception('Ошибка при создании обзора: $e');
    }
  }

  // Обновить обзор (для будущего функционала)
  Future<void> updateReview(Review review) async {
    try {
      await firestore.collection('reviews').doc(review.id).update(review.toMap());
    } catch (e) {
      throw Exception('Ошибка при обновлении обзора: $e');
    }
  }

  // Удалить обзор (для будущего функционала)
  Future<void> deleteReview(String reviewId) async {
    try {
      await firestore.collection('reviews').doc(reviewId).delete();
    } catch (e) {
      throw Exception('Ошибка при удалении обзора: $e');
    }
  }

  // Получить обзор по ID исходного поста
  Future<Review?> getReviewBySourcePost(String postId) async {
    try {
      final querySnapshot = await firestore
          .collection('reviews')
          .where('sourcePostId', isEqualTo: postId)
          .limit(1)
          .get();
      
      if (querySnapshot.docs.isNotEmpty) {
        return Review.fromMap(querySnapshot.docs.first.data());
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
