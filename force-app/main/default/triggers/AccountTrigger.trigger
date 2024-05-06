trigger AccountTrigger on Account(before insert, before update, after insert, after update) {
    new Triggers()

    .bind(Triggers.Evt.afterinsert, new CreateAccountContactHandler())

    .manage();
}