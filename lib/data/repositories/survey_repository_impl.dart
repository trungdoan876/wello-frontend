import '../../domain/repositories/survey_repository.dart';
import '../data_source/survey_remote_data_source.dart';
import '../models/requests/survey_request_model.dart';
import '../models/responses/survey_response_model.dart';

/// Implementation of survey repository
class SurveyRepositoryImpl implements SurveyRepository {
  final SurveyRemoteDataSource _remoteDataSource;

  SurveyRepositoryImpl({SurveyRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? SurveyRemoteDataSource();

  @override
  Future<SurveyResponseModel> submitSurvey(SurveyRequestModel request) async {
    try {
      return await _remoteDataSource.submitSurvey(request: request);
    } catch (e) {
      rethrow;
    }
  }
}
