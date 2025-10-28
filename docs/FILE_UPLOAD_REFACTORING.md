# File Upload Category Detection Refactoring

## Overview
The file upload system has been refactored to automatically detect file categories from extensions, eliminating the need to manually pass `FileUploadCategory` parameters.

## Changes Summary

### 1. Enhanced `FileUploadCategory` Enum (`upload_model.dart`)

#### New Static Methods:
- **`fromExtension(String filePath)`** - Automatically determines the upload category from a file's extension
  - Returns `FileUploadCategory?` (null if extension not supported)
  - Checks against all category extensions

- **`isExtensionAllowed(String filePath)`** - Validates if a file extension is allowed in any category
  - Returns `bool`

- **`allMediaExtensions`** - Static getter for all media extensions (images + videos)
  - Returns: `['jpg', 'jpeg', 'png', 'mp4', 'mov', 'avi', 'webm']`

- **`allFileExtensions`** - Static getter for all file/document extensions
  - Returns: `['pdf', 'doc', 'docx', 'xls', 'xlsx', 'txt', 'zip']`

#### Example Usage:
```dart
final category = FileUploadCategory.fromExtension('photo.jpg');
// Returns: FileUploadCategory.messageImage

final isAllowed = FileUploadCategory.isExtensionAllowed('document.pdf');
// Returns: true
```

### 2. Refactored `PickerHelper` (`picker_helper.dart`)

All picker methods now return **records** with both the file and its detected category:

#### Updated Methods:

**`pickMediaWithValidation(BuildContext context)`**
- **Before**: Required `FileUploadCategory category` parameter
- **After**: Automatically detects category from file extension
- **Returns**: `({File file, FileUploadCategory category})?`
- **Validates**: 
  - File extension is supported
  - File is image or video
  - File size is within limits

**`pickFile(BuildContext context)`**
- **Before**: Returned `File?`
- **After**: Returns file with detected category
- **Returns**: `({File file, FileUploadCategory category})?`
- **Validates**:
  - Extension is in `allFileExtensions`
  - File size is within limits
- **Note**: FilePicker is restricted to document extensions only

**`pickImageFromCameraWithCategory(BuildContext context)`** *(New)*
- Returns image captured from camera with `messageImage` category
- **Returns**: `({File file, FileUploadCategory category})?`

#### Example Usage:
```dart
// Pick media (image/video)
final result = await PickerHelper.pickMediaWithValidation(context);
if (result != null) {
  print('File: ${result.file.path}');
  print('Category: ${result.category}'); // Auto-detected
}

// Pick document
final docResult = await PickerHelper.pickFile(context);
if (docResult != null) {
  print('Document: ${docResult.file.path}');
  print('Category: ${docResult.category}'); // sessionFile
}

// Camera image
final cameraResult = await PickerHelper.pickImageFromCameraWithCategory(context);
if (cameraResult != null) {
  print('Photo: ${cameraResult.file.path}');
  print('Category: ${cameraResult.category}'); // messageImage
}
```

### 3. Updated `SingleSessionCubit` (`single_session_cubit.dart`)

**`pickAndUploadMedia(BuildContext context, {bool isFile = false})`**
- **Before**: Had commented-out category parameter causing errors
- **After**: Uses automatic category detection from picker methods
- **Flow**:
  1. Calls appropriate picker (file or media)
  2. Receives `({file, category})` record
  3. Uses detected category for upload
  4. Automatically sends message with correct content type

**`pickAndUploadCameraImage(BuildContext context)`**
- **Before**: Hardcoded `FileUploadCategory.messageImage`
- **After**: Uses `pickImageFromCameraWithCategory()` for consistency
- **Benefit**: Consistent pattern across all picker methods

## Benefits

### 1. **Automatic Category Detection**
- No need to manually specify category when picking files
- Category is automatically determined from file extension
- Reduces developer errors

### 2. **Built-in Validation**
- Extension validation happens at picker level
- Clear error messages for unsupported file types
- File size validation included

### 3. **Type Safety**
- Record return types ensure file and category stay together
- Compile-time safety for category usage
- Clear API contracts

### 4. **Simplified API**
```dart
// Before (would cause errors):
final file = await PickerHelper.pickMediaWithValidation(context, category: ???);
// How to determine category before picking?

// After (automatic):
final result = await PickerHelper.pickMediaWithValidation(context);
// Category automatically detected from file extension!
```

### 5. **Extensibility**
- Easy to add new file types to categories
- Centralized extension management
- Clear mapping between extensions and categories

## Supported File Types

### Images (MESSAGE_IMAGE)
- `jpg`, `jpeg`, `png`

### Videos (SESSION_VIDEO)
- `mp4`, `mov`, `avi`, `webm`

### Audio (SESSION_AUDIO) - Treated as Unsupported
- `mp3`, `wav`
- Note: Audio files are detected but displayed as unsupported in UI

### Documents (SESSION_FILE)
- `pdf`, `doc`, `docx`, `xls`, `xlsx`, `txt`, `zip`

## Error Handling

The system provides user-friendly error messages:
- "File type not supported. Allowed: [extensions]"
- "Please select an image or video file"
- "File size is too large (max 20MB)"

## Migration Guide

### If you were using the old API:

**Old code:**
```dart
// This would fail - category was undefined
final file = await PickerHelper.pickMediaWithValidation(context, category: category);
if (file != null) {
  await MediaUpload.uploadFile(file: file, sessionId: id, category: ???);
}
```

**New code:**
```dart
final result = await PickerHelper.pickMediaWithValidation(context);
if (result != null) {
  await MediaUpload.uploadFile(
    file: result.file, 
    sessionId: id, 
    category: result.category, // Auto-detected!
  );
}
```

## Testing Recommendations

1. Test picking each file type (image, video, document)
2. Test invalid file extensions (should show error)
3. Test file size limits
4. Test camera capture
5. Verify correct categories are assigned
6. Check message content types match file types

## Future Enhancements

Potential improvements:
- Add more document formats (pptx, numbers, pages, etc.)
- Support for multiple file selection
- Custom category detection logic
- File compression before upload
- Progress tracking for large uploads

