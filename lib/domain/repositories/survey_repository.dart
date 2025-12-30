import '../../data/models/requests/survey_request_model.dart';
import '../../data/models/responses/survey_response_model.dart';

/// Repository interface for survey operations
abstract class SurveyRepository {
  /// Submit user survey and get calculated health metrics
  Future<SurveyResponseModel> submitSurvey(SurveyRequestModel request);
}
