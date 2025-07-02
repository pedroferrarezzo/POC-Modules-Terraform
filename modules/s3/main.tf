resource "aws_s3_bucket" "this" {
    for_each = var.bucket_configs
    bucket = var.instance_name
    force_destroy = tobool(each.key)
    provider = aws.sp
}

resource "aws_s3_bucket_acl" "this" {
    for_each = var.bucket_configs
    bucket = aws_s3_bucket.this[each.key].id
    acl = each.value
    depends_on = [aws_s3_bucket_ownership_controls.this]
    provider = aws.sp
}

resource "aws_s3_bucket_ownership_controls" "this" {
    for_each = var.bucket_configs
    bucket = aws_s3_bucket.this[each.key].id
    rule {
        object_ownership = "BucketOwnerPreferred"
    }
    provider = aws.sp
}