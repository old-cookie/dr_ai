/// 提供表單驗證相關的工具函數
class FormValidators {
  /// 驗證字段是否為空
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName不能為空';
    }
    return null;
  }

  /// 驗證日期範圍是否有效
  static String? validateDateRange(String? startDate, String? endDate, String fieldName) {
    if (startDate != null && endDate != null) {
      final start = DateTime.tryParse(startDate);
      final end = DateTime.tryParse(endDate);
      
      if (start != null && end != null && end.isBefore(start)) {
        return '$fieldName的結束日期不能早於開始日期';
      }
    }
    return null;
  }
  
  /// 驗證證明書號碼格式
  static String? validateCertificateNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '證明書號碼不能為空';
    }
    
    // 可根據實際需求調整證明書號碼的格式驗證邏輯
    if (value.length < 5) {
      return '證明書號碼格式不正確';
    }
    
    return null;
  }
}
