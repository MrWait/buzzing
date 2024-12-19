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
}
