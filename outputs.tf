output "my_public_ip" {
  value = "${data.external.myipaddr.result.ip}"
}

output "server" {
  value = "${aws_instance.demo-server.public_ip}"
}
