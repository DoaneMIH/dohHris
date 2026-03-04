class ApiConfig {
  // Update this to your actual backend URL
  // static const String baseUrl = 'http://10.0.2.2:8082';   // For Android emulator, use
  // static const String baseUrl = 'http://localhost:8082'; //local testing with Flutter web
  //For testing on a physical device, use your machine's local IP address
  static const String baseUrl = 'http://192.168.79.55:8082'; 
  
  static const String loginEndpoint = '/auth/login';

  // User Profile
  static const String getUserEndpoint = '/adminuser/get-profile';
  static const String updateUserEndpoint = '/adminuser/update-employee/';

  //Change Password
  static const String changePasswordEndpoint = '/adminuser/change-password/users';

  // Daily Time Record
  static const String dtrEndpoint = '/adminuser/api/v1/dtr';

  // Employee Photo
  static const String getEmployeePhoto = '/employee/image/';
  static const String updateEmployeePhotoEndpoint = '/adminuser/update-employee-photo/';

  //Family Background
  static const String getFamilyEndpoint = '/adminuser/family/get-all-family/';
  static const String updateFamilyEndpoint = '/adminuser/family/update-family/';
  static const String addFamilyEndpoint = '/adminuser/family/add-family/';
  static const String deleteFamilyEndpoint = '/adminuser/family/delete-family/';

  //Education
  static const String getEducationEndpoint = '/adminuser/education/get-all-education/';
  static const String addEducationEndpoint = '/adminuser/education/add-education/';
  static const String updateEducationEndpoint = '/adminuser/education/update-education/';
  static const String deleteEducationEndpoint = '/adminuser/education/delete-education/';

  //Work Experience
  static const String getWorkExperienceEndpoint = '/adminuser/work-experience/get-all-work-experience/';
  static const String addWorkExperienceEndpoint = '/adminuser/work-experience/add-work-experience/';
  static const String updateWorkExperienceEndpoint = '/adminuser/work-experience/update-work-experience/';
  static const String deleteWorkExperienceEndpoint = '/adminuser/work-experience/delete-work-experience/';

  //Voluntary Work
  static const String getVoluntaryWorkEndpoint = '/adminuser/voluntary-work/get-all-voluntary-work/';
  static const String addVoluntaryWorkEndpoint = '/adminuser/voluntary-work/add-voluntary-work/';
  static const String updateVoluntaryWorkEndpoint = '/adminuser/voluntary-work/update-voluntary-work/';
  static const String deleteVoluntaryWorkEndpoint = '/adminuser/voluntary-work/delete-voluntary-work/';

  //Learning and Development
  static const String getLearningEndpoint = '/adminuser/learn-dev/get-all-learn-dev/';
  static const String addLearningEndpoint = '/adminuser/learn-dev/add-learn-dev/';
  static const String updateLearningEndpoint = '/adminuser/learn-dev/update-learn-dev/';
  static const String deleteLearningEndpoint = '/adminuser/learn-dev/delete-learn-dev/';

  //Civil Service Eligibility
  static const String getEligibilityEndpoint = '/adminuser/eligibility/get-all-eligibility/';
  static const String addEligibilityEndpoint = '/adminuser/eligibility/add-eligibility/';
  static const String updateEligibilityEndpoint = '/adminuser/eligibility/update-eligibility/';
  static const String deleteEligibilityEndpoint = '/adminuser/eligibility/delete-eligibility/';

  // Other Information
  static const String getOtherInfoEndpoint = '/adminuser/other-info/get-all-other-info/';
  static const String addOtherInfoEndpoint = '/adminuser/other-info/add-other-info/';
  static const String updateOtherInfoEndpoint = '/adminuser/other-info/update-other-info/';
  static const String deleteOtherInfoEndpoint = '/adminuser/other-info/delete-other-info/';

  //Person Reference
  static const String getPersonReferenceEndpoint = '/adminuser/person-reference/get-all-person-references/';
  static const String addPersonReferenceEndpoint = '/adminuser/person-reference/add-person-reference/';
  static const String updatePersonReferenceEndpoint = '/adminuser/person-reference/update-person-reference/';
  static const String deletePersonReferenceEndpoint = '/adminuser/person-reference/delete-person-reference/';
}
  
