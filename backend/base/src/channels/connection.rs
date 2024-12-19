use loco_rs::socketioxide::extract::{AckSender, Data, SocketRef, State, TryData};

use super::state;

#[derive(serde::Serialize, serde::Deserialize, Clone, Debug)]
pub struct MessageIn {
    room: String,
    text: String,
}

#[derive(serde::Serialize)]
pub struct Messages {
    messages: Vec<state::Message>,
}

pub async fn on_connect(socket: SocketRef) {
    tracing::info!("socket  connected:{}", socket.id);

    socket.on(
        "join",
        |socket: SocketRef, Data::<String>(room), store: State<state::MessageStore>| async move {
            tracing::info!("Received join:{:?}", room);
            let _ = socket.leave_all();
            let _ = socket.join(room.clone());
            let messages = store.get(&room).await;
            let _ = socket.emit("messages", Messages { messages });
        },
    );

    socket.on(
        "message",
        |socket: SocketRef,
         Data(data): Data<MessageIn>,
         ack: AckSender,
         state: State<state::MessageStore>| {
            tracing::info!("Received message:{:?}", data);
            let response = state::Message {
                text: data.text.to_owned(),
                user: format!("anon-{}", socket.id),
                date: chrono::Utc::now(),
            };
            // store.insert(&data.room, response.clone()).await;
            // let _ = socket.within(data.room).emit("message", response);
        },
    );
}
