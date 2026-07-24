pub mod idl {
    pub mod sdk {
        include!(concat!("./idl/sdk.rs"));
    }
    pub mod command {
        include!(concat!("./idl/command.rs"));
    }
    pub mod entity {
        include!(concat!("./idl/entity.rs"));
    }
    pub mod chat {
        include!(concat!("./idl/chat.rs"));
    }
    pub mod error {
        include!(concat!("./idl/error.rs"));
    }
    pub mod user {
        include!(concat!("./idl/user.rs"));
    }
    pub mod message {
        include!(concat!("./idl/message.rs"));
    }
    pub mod feed {
        include!(concat!("./idl/feed.rs"));
    }
    pub mod dept {
        include!(concat!("./idl/dept.rs"));
    }
    pub mod pipeline {
        include!(concat!("./idl/pipeline.rs"));
    }
    pub mod setting {
        include!(concat!("./idl/setting.rs"));
    }
    pub mod calendar {
        include!(concat!("./idl/calendar.rs"));
    }
    pub mod meeting {
        include!(concat!("./idl/meeting.rs"));
    }
    pub mod mute {
        include!(concat!("./idl/mute.rs"));
    }
    pub mod invite {
        include!(concat!("./idl/invite.rs"));
    }
    pub mod join_request {
        include!(concat!("./idl/join_request.rs"));
    }
    pub mod pin {
        include!(concat!("./idl/pin.rs"));
    }
    pub mod thread {
        include!(concat!("./idl/thread.rs"));
    }
    pub mod presence {
        include!(concat!("./idl/presence.rs"));
    }
    pub mod typing {
        include!(concat!("./idl/typing.rs"));
    }
    pub mod search {
        include!(concat!("./idl/search.rs"));
    }
    pub mod timer {
        include!(concat!("./idl/timer.rs"));
    }
    pub mod translate {
        include!(concat!("./idl/translate.rs"));
    }
    pub mod openapp {
        include!(concat!("./idl/openapp.rs"));
    }
    pub mod card {
        include!(concat!("./idl/card.rs"));
    }
}
