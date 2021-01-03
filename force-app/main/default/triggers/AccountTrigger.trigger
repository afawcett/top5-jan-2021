trigger AccountTrigger on Account (before insert) {
    Request reqInfo = Request.getCurrent();
    System.Quiddity quiddity = reqInfo.getQuiddity();
    System.debug('Quiddity is ' + quiddity);
}