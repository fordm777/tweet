output "my_public_ip" {
  value = "${data.external.myipaddr.result.ip}"
}

output "public-ips" {
  #value = "${aws_instance.demo-server[*].public_ip}"
  #value = element([for v in values(aws_instance.demo-server) : v.public_ip], 0)
  #value = aws_instance.demo-server["jenkins-master"].public_ip
  value = { for i in aws_instance.demo-server: i.tags.Name => "${i.id}:${i.public_ip}" }
}
