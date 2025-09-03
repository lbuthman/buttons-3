public with sharing class ImageSaver {

    @AuraEnabled
    public static Boolean saveImageToFile(String title, String base64Image) {
        String sanitizeBase64 = base64Image.remove('data:image/png;base64,');

        ContentVersion reportImage = new ContentVersion(
            Title = title,
            VersionData = EncodingUtil.base64Decode(sanitizeBase64),
            ContentLocation = 'S',
            PathOnClient = title + '.png'
        );
        insert reportImage;

        return true;
    }
}