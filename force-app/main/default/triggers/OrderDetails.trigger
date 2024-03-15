trigger OrderDetails on Order (after insert, after delete) {
    new OrderDetailsHandler().run();
}