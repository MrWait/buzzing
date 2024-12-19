use tracing_subscriber::Layer;

#[allow(dead_code)]
pub struct LogLayer;

impl<S> Layer<S> for LogLayer
where
    S: tracing::Subscriber,
{
    fn on_event(
        &self,
        event: &tracing::Event<'_>,
        _ctx: tracing_subscriber::layer::Context<'_, S>,
    ) {
        println!("{:?}", event);
    }
}

#[allow(dead_code)]
struct PrintlnVisitor;

impl tracing::field::Visit for PrintlnVisitor {
    fn record_f64(&mut self, _field: &tracing::field::Field, _value: f64) {}

    fn record_debug(&mut self, _field: &tracing::field::Field, value: &dyn std::fmt::Debug) {
        println!("{:?}", value);
    }
}
