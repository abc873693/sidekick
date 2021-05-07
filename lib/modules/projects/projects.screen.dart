import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:responsive_grid/responsive_grid.dart';

import '../../components/atoms/typography.dart';
import '../../utils/notify.dart';
import '../common/atoms/checkbox.dart';
import '../common/atoms/refresh_button.dart';
import '../common/organisms/screen.dart';
import '../settings/settings.provider.dart';
import 'components/project_list_item.dart';
import 'components/projects_empty.dart';
import 'projects.provider.dart';

class ProjectsScreen extends HookWidget {
  const ProjectsScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final projects = useProvider(projectsProvider);
    final filteredProjects = useState(projects.list);

    final settings = useProvider(settingsProvider);
    void onRefresh() async {
      await context.read(projectsProvider.notifier).reloadAll(withDelay: true);
      notify('Projects Refreshed');
    }

    useEffect(() {
      if (settings.sidekick.onlyProjectsWithFvm) {
        filteredProjects.value =
            projects.list.where((p) => p.pinnedVersion != null).toList();
      } else {
        filteredProjects.value = [...projects.list];
      }
      return;
    }, [projects.list, settings.sidekick]);

    if (projects.list.isEmpty &&
        filteredProjects.value.isEmpty &&
        !projects.loading) {
      return const EmptyProjects();
    }

    return SkScreen(
      title: 'Projects',
      processing: projects.loading,
      actions: [
        Caption('${projects.list.length} Projects'),
        const SizedBox(width: 10),
        Tooltip(
          message: 'Only display projects that have versions pinned',
          child: SkCheckBox(
            label: 'FVM Only',
            value: settings.sidekick.onlyProjectsWithFvm,
            onChanged: (value) {
              settings.sidekick.onlyProjectsWithFvm = value;
              context.read(settingsProvider.notifier).save(settings);
            },
          ),
        ),
        const SizedBox(width: 10),
        RefreshButton(
          refreshing: projects.loading,
          onPressed: onRefresh,
        ),
      ],
      child: CupertinoScrollbar(
        child: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: ResponsiveGridList(
              desiredItemWidth: 290,
              minSpacing: 0,
              children: filteredProjects.value.map((project) {
                return Padding(
                  padding: const EdgeInsets.only(top: 10, right: 10),
                  child: ProjectListItem(
                    project,
                    versionSelect: true,
                    key: Key(project.projectDir.path),
                  ),
                );
              }).toList()),
        ),
      ),
    );
  }
}
