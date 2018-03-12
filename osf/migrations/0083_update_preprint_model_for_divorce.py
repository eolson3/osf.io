# -*- coding: utf-8 -*-
# Generated by Django 1.11.9 on 2018-03-12 15:44
from __future__ import unicode_literals

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('osf', '0082_merge_20180213_1502'),
    ]

    operations = [
            migrations.CreateModel(
                name='PreprintContributor',
                fields=[
                    ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                    ('read', models.BooleanField(default=False)),
                    ('write', models.BooleanField(default=False)),
                    ('admin', models.BooleanField(default=False)),
                    ('visible', models.BooleanField(default=False)),
                ],
            ),
            migrations.AddField(
                model_name='preprintservice',
                name='creator',
                field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.SET_NULL, related_name='preprints_created', to=settings.AUTH_USER_MODEL),
            ),
            migrations.AddField(
                model_name='preprintservice',
                name='description',
                field=models.TextField(blank=True, default=b''),
            ),
            migrations.AddField(
                model_name='preprintservice',
                name='tags',
                field=models.ManyToManyField(related_name='preprintservice_tagged', to='osf.Tag'),
            ),
            migrations.AddField(
                model_name='preprintservice',
                name='title',
                field=models.TextField(default='Untitled', validators=[osf.models.validators.validate_title]),
                preserve_default=False,
            ),
            migrations.AddField(
                model_name='preprintcontributor',
                name='preprint',
                field=models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='osf.PreprintService'),
            ),
            migrations.AddField(
                model_name='preprintcontributor',
                name='user',
                field=models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to=settings.AUTH_USER_MODEL),
            ),
            migrations.AddField(
                model_name='preprintservice',
                name='_contributors',
                field=models.ManyToManyField(related_name='preprints', through='osf.PreprintContributor', to=settings.AUTH_USER_MODEL),
            ),
            migrations.AlterUniqueTogether(
                name='preprintcontributor',
                unique_together=set([('user', 'preprint')]),
            ),
            migrations.AlterOrderWithRespectTo(
                name='preprintcontributor',
                order_with_respect_to='preprint',
            ),
    ]